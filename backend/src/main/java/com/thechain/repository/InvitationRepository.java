package com.thechain.repository;

import com.thechain.entity.Invitation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface InvitationRepository extends JpaRepository<Invitation, UUID> {

    Optional<Invitation> findByChildId(UUID childId);

    Optional<Invitation> findByParentId(UUID parentId);

    List<Invitation> findAllByParentId(UUID parentId);

    List<Invitation> findAllByParentIdAndStatus(UUID parentId, Invitation.InvitationStatus status);

    @Query("SELECT i FROM Invitation i WHERE i.parentId = :parentId AND i.status = 'ACTIVE'")
    Optional<Invitation> findActiveInvitationByParentId(@Param("parentId") UUID parentId);

    /**
     * Get list of wastedChildIds for a parent - children who were removed from chain
     * This provides relational storage for User.wastedChildIds field
     */
    @Query("SELECT i.childId FROM Invitation i WHERE i.parentId = :parentId AND i.status = 'REMOVED'")
    List<UUID> findWastedChildIdsByParentId(@Param("parentId") UUID parentId);

    @Query("SELECT COUNT(i) FROM Invitation i WHERE i.status = 'ACTIVE'")
    long countActiveInvitations();

    boolean existsByChildIdAndStatus(UUID childId, Invitation.InvitationStatus status);
}
